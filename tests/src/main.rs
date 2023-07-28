use anyhow::Result;
use serde::{Deserialize, Serialize};
use common::{list_pods, random_payload, retry_get, retry_put, retry_post};
mod common;

const RETRY_TIMES: u32 = 5;
const INTERVAL_IN_SECS: u64 = 10;

#[tokio::main]
async fn main() {
    // let host_port = 8002;
    // let create_order_url = format!("http://localhost:{}/order", host_port);

    // // check the test pod is running
    // let cluster_name = format!("k3d-{}-{}", "test", "cluster");
    // list_pods(&cluster_name).await;

    // // curl for hello
    // println!(" >>> curl {}", create_order_url);
    // let payload = random_payload().await;
    // retry_post(
    //     &create_order_url,
    //     &payload,
    //     RETRY_TIMES,
    //     INTERVAL_IN_SECS,
    // )
    // .await;

}

#[tokio::test]
async fn create_order_test() -> Result<()> {
    let host_port = 8002;
    let create_order_url = format!("http://localhost:{}/order", host_port);
    // chaining .await will yield our query result
    let payload = random_payload().await;

    let client  = reqwest::Client::new();
    let response = client
        .post(create_order_url)
        .body(payload)
        .header("Content-Type", "application/json")
        .send().await.unwrap();
    println!("{:?}", response.status());
    // match response.status() {
    //     reqwest::StatusCode::ACCEPTED => {
    //         println!("Got a 202 response!");
    //         match response.json::<OrderCreatedResponse>().await {
    //             Ok(parsed) => println!("Success! {:?}", parsed),
    //             Err(_) => println!("Hm, the response didn't match the shape we expected."),
    //         };
    //     },
    //     reqwest::StatusCode::UNAUTHORIZED => {
    //         println!("Need to grab a new token");
    //     },
    //     _ => {
    //         panic!("Uh oh! Something unexpected happened.");
    //     },
    // };

    let result = response.text().await;
    println!("{:?}", result);

    Ok(())
}

#[derive(Serialize, Deserialize, Debug)]
struct Task {
    href: String,
    id: u64,
    status: String
}

#[derive(Serialize, Deserialize, Debug)]
struct OrderCreatedResponse {
    task: Task
}

