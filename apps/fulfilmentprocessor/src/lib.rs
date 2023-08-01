use std::env::var;
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
    let address: String = var(REDIS_ADDRESS_ENV)?;

    let message_body =  from_utf8(&message)?;
    println!("Order Received: {}", message_body);

    // Extract order details from request json.
    // TODO: This can be a typed struct from order-management crate.
    let order: Value = serde_json::from_str(message_body)?;
    let order_id = order["id"].as_u64().unwrap() as u32;

    // Update order status in Redis KV store.
    redis::set(&address, &order_id.to_string(), "fulfilled".as_bytes()).unwrap();

    Ok(())
}
