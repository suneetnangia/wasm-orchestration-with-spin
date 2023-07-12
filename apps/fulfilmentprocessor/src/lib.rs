use anyhow::Result;
use bytes::Bytes;
use spin_sdk::{redis_component, redis};
use std::str::from_utf8;
use serde_json::Value;

// The environment variable set in `spin.toml` that points to the
// address of the Redis server that the component will publish
// a message to.
const REDIS_ADDRESS_ENV: &str = "REDIS_ADDRESS";

#[redis_component]
fn on_message(message: Bytes) -> Result<()> {
    let address: String = std::env::var(REDIS_ADDRESS_ENV)?;

    let message_body =  from_utf8(&message)?;
    println!("Order received: {}", message_body);

    // Extract order details from request json.    
    let json_value: Value = serde_json::from_str(message_body)?;
    let order_id = json_value["order_id"].as_str().unwrap();

    // Update order status in Redis KV store.
    redis::set(&address, order_id, "fulfilled".as_bytes()).unwrap();

    Ok(())
}
