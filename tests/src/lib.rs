use anyhow::Result;
use common::{random_payload, send_get, send_post, OrderCreatedResponse, OrderStatusResponse};
use std::time;
mod common;

const RETRY_TIMES: u32 = 5;
const INTERVAL_IN_SECS: u64 = 5;
const ORDER_STATUS_CREATED: &str= "created";
const ORDER_STATUS_FULFILLED: &str = "fulfilled";

#[tokio::test]
async fn create_order_test() -> Result<()> {
    let mut i = 0;
    let host_port = 8002;
    let base_url = format!("http://localhost:{}", host_port);
    let create_order_url = format!("{}/order", base_url);

    // create random payload
    let payload = random_payload().await;
    // create order
    let response = send_post(&create_order_url, payload).await.unwrap();

    match response.status() {
        reqwest::StatusCode::ACCEPTED => {
            // deserialize response
            let order_created = response.json::<OrderCreatedResponse>().await.unwrap();
            // assert status
            assert_eq!(order_created.task.status.to_lowercase(), "created");
            loop {
                // wait for order to be processed and to start next retry
                tokio::time::sleep(time::Duration::from_secs(INTERVAL_IN_SECS)).await;
                // get order status from address provided from order creation
                let get_order_status_url = format!("{}{}", base_url, order_created.task.href);
                let get_order_status_response = send_get(&get_order_status_url).await.unwrap();

                match get_order_status_response.status() {
                    reqwest::StatusCode::OK => {
                        // deserialize response
                        let order_status = get_order_status_response
                            .json::<OrderStatusResponse>()
                            .await
                            .unwrap();
                        
                        // assert status
                        if order_status.status.to_lowercase().as_str() == ORDER_STATUS_FULFILLED {
                            assert_eq!(order_status.status.to_lowercase(), ORDER_STATUS_FULFILLED);
                            assert_eq!(order_status.id, order_created.task.id.to_string());
                            break;
                        }
                    }
                    _ => {
                        panic!(
                            "Request to {:?} failed - {:?}",
                            get_order_status_url,
                            &get_order_status_response.text().await
                        );
                    }
                };
                i += 1;
                if i == RETRY_TIMES {
                    break;
                }
            }
        }
        _ => {
            panic!(
                "Request to {:?} failed - {:?}",
                create_order_url,
                response.text().await
            );
        }
    };

    Ok(())
}
