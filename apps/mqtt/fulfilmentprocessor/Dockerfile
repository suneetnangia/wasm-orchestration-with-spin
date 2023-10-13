FROM scratch AS build
WORKDIR /workspaces/wasm-orchestration-with-spin/apps/mqtt/fulfilmentprocessor
COPY . .

FROM scratch
COPY --from=build /workspaces/wasm-orchestration-with-spin/apps/mqtt/fulfilmentprocessor/spin.toml .
COPY --from=build /workspaces/wasm-orchestration-with-spin/apps/mqtt/fulfilmentprocessor/target/wasm32-wasi/release/fulfilmentprocessor_mqtt.wasm ./target/wasm32-wasi/release/fulfilmentprocessor_mqtt.wasm
