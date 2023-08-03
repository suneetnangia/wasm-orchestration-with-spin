use anyhow::{anyhow, Result};
use order_management::Order;
use rand::Rng;
use serde_json::json;
use spin_sdk::{
    http::{Request, Response},
    http_component, redis,
};
use std::env::var;

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

    let http_response_body = generate_http_accept_response(order_id);

    let http_response = http::Response::builder()
        .status(http::StatusCode::ACCEPTED)
        .body(Some(http_response_body.into()))?;

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

fn generate_http_accept_response(order_id: u32) -> String {
    // TODO: This can be a typed object from order-management crate.
    let mut response_body = json!({
          "task": {
              "href": "",
              "id": "",
              "status": "created"
          }
    });

    response_body["task"]["href"] = format!("/order/{}", order_id).into();
    response_body["task"]["id"] = order_id.into();

    response_body.to_string()
}
