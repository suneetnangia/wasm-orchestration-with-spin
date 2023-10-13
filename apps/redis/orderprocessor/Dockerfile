FROM scratch AS build
WORKDIR /workspaces/wasm-orchestration-with-spin/apps/redis/orderprocessor
COPY . .

FROM scratch
COPY --from=build /workspaces/wasm-orchestration-with-spin/apps/redis/orderprocessor/spin.toml .
# Copy wasm components which are required to run the application
COPY --from=build /workspaces/wasm-orchestration-with-spin/apps/redis/orderprocessor/target/wasm32-wasi/release/receiver_redis.wasm ./target/wasm32-wasi/release/receiver_redis.wasm
COPY --from=build /workspaces/wasm-orchestration-with-spin/apps/redis/orderprocessor/target/wasm32-wasi/release/statusprovider_redis.wasm ./target/wasm32-wasi/release/statusprovider_redis.wasm
