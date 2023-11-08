FROM scratch AS build
WORKDIR /workspaces/wasm-orchestration-with-spin/apps/shared/orderstatusprovider
COPY . .

FROM scratch
COPY --from=build /workspaces/wasm-orchestration-with-spin/apps/shared/orderstatusprovider/spin.toml .
# Copy wasm components which are required to run the application
COPY --from=build /workspaces/wasm-orchestration-with-spin/apps/shared/orderstatusprovider/target/wasm32-wasi/release/orderstatusprovider.wasm ./target/wasm32-wasi/release/orderstatusprovider.wasm
