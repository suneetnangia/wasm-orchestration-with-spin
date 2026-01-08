FROM scratch AS build
WORKDIR /workspaces/wasm-orchestration-with-spin/apps/redis/fulfilmentprocessor
COPY . .

FROM scratch
COPY --from=build /workspaces/wasm-orchestration-with-spin/apps/redis/fulfilmentprocessor/spin.toml .
COPY --from=build /workspaces/wasm-orchestration-with-spin/apps/redis/fulfilmentprocessor/target/wasm32-wasip1/release/fulfilmentprocessor_redis.wasm ./target/wasm32-wasip1/release/fulfilmentprocessor_redis.wasm
