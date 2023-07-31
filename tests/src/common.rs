use serde:: {Serialize, Deserialize};
use anyhow::Result;
use rand::{distributions::Alphanumeric, Rng};

pub async fn send_get(
    url: &str
) -> Result<reqwest::Response, reqwest::Error> {
    let client  = reqwest::Client::new();
    let response = client
    .get(url)
    .header("Content-Type", "application/json")
    .send().await;

    response
}

pub async fn send_post(
    url: &str,
    payload: String
) -> Result<reqwest::Response, reqwest::Error> {
    let client = reqwest::Client::new();
    let response = client
        .post(url)
        .body(payload)
        .header("Content-Type", "application/json")
        .send()
        .await;

    response
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
pub struct Task {
    pub href: String,
    pub id: u64,
    pub status: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct OrderCreatedResponse {
    pub task: Task,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct OrderStatusResponse {
    pub id: String,
    pub status: String,
}

