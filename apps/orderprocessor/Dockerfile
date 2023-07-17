FROM scratch AS build
WORKDIR /workspaces/wasm-orchestration-with-spin/apps/orderprocessor
COPY . .

FROM scratch
COPY --from=build /workspaces/wasm-orchestration-with-spin/apps/orderprocessor/spin.toml .
# Copy wasm components which are required to run the application
COPY --from=build /workspaces/wasm-orchestration-with-spin/apps/orderprocessor/target/wasm32-wasi/release/receiver.wasm ./target/wasm32-wasi/release/receiver.wasm
COPY --from=build /workspaces/wasm-orchestration-with-spin/apps/orderprocessor/target/wasm32-wasi/release/statusprovider.wasm ./target/wasm32-wasi/release/statusprovider.wasm
