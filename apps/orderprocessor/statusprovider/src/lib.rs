use anyhow::{anyhow, Result};

use spin_sdk::{
    http::{Request, Response, internal_server_error},
    http_component, redis,
};

// The environment variable set in `spin.toml` that points to the
// address of the Redis server that the component will publish
// a message to.
const REDIS_ADDRESS_ENV: &str = "REDIS_ADDRESS";

/// A simple Spin HTTP component.
#[http_component]
fn handle_entry(req: Request) -> Result<Response> {
    let address = std::env::var(REDIS_ADDRESS_ENV)?;

    let status_code = 200;

    // Extract order id from request.
    let path = req.uri().path();
    let order_id = path.split_terminator('/').last().unwrap();
    
    println!("Order Id: {}", order_id);

    // Get order status from Redis KV store.
    let status = redis::get(&address, order_id).unwrap();    
    let status_val = String::from_utf8(status).unwrap(); 

    // Send pseudo 200 response to client for now.
    let response_body = format!("{{ \"status\": {:?}}}", status_val);

    println!("Status Response: {}", response_body);
    
    let response = http::Response::builder()
    .status(status_code)
    .body(Some(response_body.into()))?;

        Ok(response)
}
