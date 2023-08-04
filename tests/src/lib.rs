use anyhow::Result;
use common::{random_order_details, send_get, send_post};
use reqwest::StatusCode;
use std::time;
mod common;
use order_management::{OrderAccepted, OrderStatus};
use url::Url;

const MAX_RETRY_ATTEMPTS: u32 = 5;
const INTERVAL_IN_SECS: u64 = 5;
const ORDER_STATUS_CREATED: &str = "created";
const ORDER_STATUS_FULFILLED: &str = "fulfilled";

#[tokio::test]
async fn create_order_test() -> Result<()> {
    let mut retry_count = 0;
    let host_port = 8002;
    let base_url = Url::parse(format!("http://localhost:{}", host_port).as_str())?;
    let create_order_url = base_url.join("order")?;

    // create random payload
    let payload = random_order_details().await;
    // create order
    let response = send_post(create_order_url.as_str(), payload).await.unwrap();

    match response.status() {
        ACCEPTED => {
            // deserialize response
            let order_created = response.json::<OrderAccepted>().await.unwrap();
            // assert status
            assert_eq!(
                order_created.http_accept_task.status.to_lowercase(),
                ORDER_STATUS_CREATED
            );
            loop {
                retry_count += 1;
                // wait for order to be processed and to start next retry
                tokio::time::sleep(time::Duration::from_secs(INTERVAL_IN_SECS)).await;
                // get order status from address provided from order creation
                let get_order_status_url =
                    base_url.join(order_created.http_accept_task.href.as_str())?;
                let get_order_status_response =
                    send_get(get_order_status_url.as_str()).await.unwrap();

                match get_order_status_response.status() {
                    OK => {
                        // deserialize response
                        let order_status = get_order_status_response
                            .json::<OrderStatus>()
                            .await
                            .unwrap();

                        // assert status
                        if order_status.status.to_lowercase().as_str() == ORDER_STATUS_FULFILLED
                            || retry_count == MAX_RETRY_ATTEMPTS
                        {
                            assert_eq!(
                                order_status.id,
                                order_created.http_accept_task.id.to_string()
                            );
                            assert_eq!(order_status.status.to_lowercase(), ORDER_STATUS_FULFILLED);
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
