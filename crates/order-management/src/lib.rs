//TODO: This may eventually be WIT types but for now keep them as structs.

use serde:: {Serialize, Deserialize};
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