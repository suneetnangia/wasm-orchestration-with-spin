use anyhow::{anyhow, Result};
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

    println!("{:?}", req.headers());

    let status_code = 200;
    let header_name = "foo";
    let header_value = "bar";
    let response_body = "Hello, Redis Spin!";

    let response = http::Response::builder()
        .status(status_code)
        .header(header_name, header_value)
        .body(Some(response_body.into()))?;

    // Send message to Redis channel.
    // Get the message to publish from the Redis key "mykey"
    let payload = redis::get(&address, "order001").map_err(|_| anyhow!("Error querying Redis"))?;

    // Publish to Redis
    let _ = match redis::publish(&address, &channel, &payload) {
        Ok(()) => Ok(http::Response::builder().status(200).body(None)?),
        Err(_e) => internal_server_error(),
    };

    Ok(response)
}
