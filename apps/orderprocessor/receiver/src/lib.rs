use anyhow::{anyhow, Result};
use order_management::{HttpAcceptTask, Order, OrderAccepted};
use rand::Rng;
use serde_json::json;
use spin_sdk::{
    http::{Request, Response},
    http_component, redis,
};
use std::{env::var, io::Read};

// The environment variable is set in `spin.toml` that points to the
// address of the Redis server that the component will publish
// a message to.
const REDIS_ADDRESS_ENV: &str = "REDIS_ADDRESS";

// The environment variable is set in `spin.toml` that specifies
// the Redis channel that the component will publish to.
const REDIS_CHANNEL_ENV: &str = "REDIS_CHANNEL";

// New order processing component.
#[http_component]
fn handle_receiver(req: Request) -> Result<Response> {
    let address = var(REDIS_ADDRESS_ENV)?;
    let channel = var(REDIS_CHANNEL_ENV)?;

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
    let order_details = String::from_utf8(request_body.to_vec())?;
    let mut order: Order = serde_json::from_str(&order_details)?;

    // Update order id and status.
    order.id = order_id;
    order.status = "created".to_string();

    // Send order to Redis channel.
    let payload = serde_json::to_string(&order)?;

    // Update order status in Redis KV store.
    redis::set(&address, &order_id.to_string(), order.status.as_bytes()).unwrap();

    // Publish to Redis
    redis::publish(&address, &channel, payload.as_bytes()).unwrap();

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
