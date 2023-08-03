//TODO: This may eventually be WIT types but for now keep them as structs.

use serde::{Deserialize, Serialize};
#[derive(Serialize, Deserialize, Debug)]
pub struct Order {
    #[serde(default)]
    pub id: u32,
    pub details: String,
    // TODO: we will use enum for status.
    #[serde(default)]
    #[serde(rename = "status")]
    pub status: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct HttpAcceptTask {
    pub href: String,
    pub id: u32,
    pub status: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct OrderCreated {
    #[serde(rename = "task")]
    pub http_accept_task: HttpAcceptTask,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct OrderStatus {
    pub id: String,
    pub status: String,
}
