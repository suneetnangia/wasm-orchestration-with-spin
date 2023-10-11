use anyhow::{anyhow, Result};
use order_management::{HttpAcceptTask, Order, OrderAccepted};
use rand::Rng;
use spin_sdk::{
    http::{Request, Response},
    http_component, redis, mqtt,
};
use std::env::var;


// The environment variable is set in `spin.toml` that points to the
// address of the Redis broker that the component will update KV to.
const REDIS_ADDRESS_ENV: &str = "REDIS_ADDRESS";

// The environment variable is set in `spin.toml` that points to the
// address of the Mosquitto broker that the component will publish
// a message to.
const MOSQUITTO_ADDRESS_ENV: &str = "MQTT_ADDRESS";

// The environment variable is set in `spin.toml` that specifies
// the Mosquitto topic that the component will publish to.
const MOSQUITTO_TOPIC_ENV: &str = "MQTT_TOPIC";

// New order processing component.
#[http_component]
fn handle_receiver(req: Request) -> Result<Response> {
    let redis_address = var(REDIS_ADDRESS_ENV)?;
    let mqtt_address = var(MOSQUITTO_ADDRESS_ENV)?;
    let mqtt_topic = var(MOSQUITTO_TOPIC_ENV)?;

    // Generate random order id
    // TODO: we will move this function to another wasm component as a nano service.
    let mut order_number_generator = rand::thread_rng();
    let order_id = order_number_generator.gen_range(100000..999999);

    let payload = generate_http_accept_response(order_id);
    let payload = serde_json::to_vec(&payload).unwrap();

    let http_response = http::Response::builder()
        .status(http::StatusCode::ACCEPTED)
        .body(Some(payload.into()))?;

    // Extract order details from request json and deserialise it.
    let request_body = req.body().clone().ok_or(anyhow!("No request body"))?;
    let mut order: Order = serde_json::from_slice(&request_body)?;

    // Update order id and status.
    order.id = order_id;
    order.status = "created".to_string();

    // Send order to Redis channel.
    let payload = serde_json::to_string(&order)?;

    // Update order status in Redis KV store.
    redis::set(&redis_address, &order_id.to_string(), order.status.as_bytes()).unwrap();

    // Publish to Mosquitto
    mqtt::publish(&mqtt_address, mqtt::Qos::AtLeastOnce, &mqtt_topic, payload.as_bytes(),).unwrap();

    Ok(http_response)
}

fn generate_http_accept_response(order_id: u32) -> OrderAccepted {
    let task = HttpAcceptTask {
        href: format!("/order/{}", order_id),
        id: order_id,
        status: "created".to_string(),
    };

    OrderAccepted {
        http_accept_task: task,
    }
}
