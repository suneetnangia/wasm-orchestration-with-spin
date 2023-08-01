use anyhow::Result;
use rand::{distributions::Alphanumeric, Rng};
use reqwest::{Client, Error, Response};
use serde::{Deserialize, Serialize};

pub async fn send_get(url: &str) -> Result<Response, Error> {
    let client = Client::new();
    client
        .get(url)
        .header(
            http::header::CONTENT_TYPE,
            http::HeaderValue::from_static("application/json"),
        )
        .send()
        .await
}

pub async fn send_post(url: &str, payload: String) -> Result<Response, Error> {
    let client = Client::new();
    client
        .post(url)
        .body(payload)
        .header(
            http::header::CONTENT_TYPE,
            http::HeaderValue::from_static("application/json"),
        )
        .send()
        .await
}

pub async fn random_payload() -> String {
    let rng = rand::thread_rng();
    let random_string: String = rng
        .sample_iter(&Alphanumeric)
        .take(30)
        .map(char::from)
        .collect();

    let payload: String = format!("{{\"details\":\"{}\"}}", random_string);
    payload
}

#[derive(Serialize, Deserialize, Debug)]
pub struct HttpAcceptTask {
    pub href: String,
    pub id: u64,
    pub status: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct OrderCreatedResponse {
    #[serde(rename = "task")]
    pub http_accept_task: HttpAcceptTask,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct OrderStatusResponse {
    pub id: String,
    pub status: String,
}
