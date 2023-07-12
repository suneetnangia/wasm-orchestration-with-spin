use anyhow::{anyhow, Result};
use serde_json::Value;

use spin_sdk::{
    http::{Request, Response, internal_server_error},
    http_component, redis,
};

// The environment variable set in `spin.toml` that points to the
// address of the Redis server that the component will publish
// a message to.
const REDIS_ADDRESS_ENV: &str = "REDIS_ADDRESS";

// The environment variable set in `spin.toml` that specifies
// the Redis channel that the component will publish to.
const REDIS_CHANNEL_ENV: &str = "REDIS_CHANNEL";

/// A simple Spin HTTP component.
#[http_component]
fn handle_entry(req: Request) -> Result<Response> {
    let address = std::env::var(REDIS_ADDRESS_ENV)?;
    let channel = std::env::var(REDIS_CHANNEL_ENV)?;    

    let status_code = 202;

    // Send pseudo 202 response to client for now.
    let response_body = r#"{
        "task": {
            "href": "/api/task/2130040",
            "id": "2130041"
            }
        }"#;

    let response = http::Response::builder()
        .status(status_code)
        .body(Some(response_body.into()))?;
    
    // Extract order details from request json.
    let request_body = req.body().clone().ok_or(anyhow!("No request body"))?;
    let order_details = String::from_utf8(request_body.to_vec())?;
    let json_value: Value = serde_json::from_str(&order_details)?;
    let order_id = json_value["order_id"].as_str().unwrap();

    // Send order to Redis channel.
    let payload = order_details.as_bytes();

    // Update order status in Redis KV store.
    redis::set(&address, order_id, "created".as_bytes()).unwrap();

    // Publish to Redis
    let _ = match redis::publish(&address, &channel, payload) {
        Ok(()) => Ok(http::Response::builder().status(200).body(None)?),
        Err(_e) => internal_server_error(),
    };

    Ok(response)
}
