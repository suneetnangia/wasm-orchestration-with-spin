use anyhow::Result;
use std::env::var;
use spin_sdk::{
    http::{Request, Response},
    http_component, redis,
};

// The environment variable set in `spin.toml` that points to the
// address of the Redis server that the component will publish
// a message to.
const REDIS_ADDRESS_ENV: &str = "REDIS_ADDRESS";

/// Http handler for status provider.
#[http_component]
fn handle_statusprovider(req: Request) -> Result<Response> {
    let address = var(REDIS_ADDRESS_ENV)?;

    // Extract order Id from http query string.
    let query_string = req.uri().path();
    let order_id = query_string.split_terminator('/').last().unwrap();
    
    println!("Received Order Id: {}", order_id);

    // Get order status from Redis KV store.
    let order_status = redis::get(&address, order_id).unwrap();    
    let order_status = String::from_utf8(order_status).unwrap(); 
    
    let response_body = format!("{{ \"status\": {:?}}}", order_status);

    println!("Status Response: {}", response_body);
    
    // Send Http OK response to client with status details.
    let response = http::Response::builder()
    .status(http::StatusCode::OK)
    .body(Some(response_body.into()))?;

    Ok(response)
}
