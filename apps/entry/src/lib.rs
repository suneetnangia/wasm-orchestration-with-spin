use anyhow::Result;
use spin_sdk::{
    http::{Request, Response},
    http_component,
};

/// A simple Spin HTTP component.
#[http_component]
fn handle_entry(req: Request) -> Result<Response> {
    println!("{:?}", req.headers());

    let status_code = 200;
    let header_name = "foo";
    let header_value = "bar";
    let response_body = "Hello, Spin!";

    let response = http::Response::builder()
        .status(status_code)
        .header(header_name, header_value)
        .body(Some(response_body.into()))?;

    Ok(response)
}
