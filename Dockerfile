# 第一阶段：构建应用
FROM rust:1.67 AS builder

WORKDIR /usr/src/myapp

# 配置 Cargo 使用中国科技大学镜像源加速依赖下载
RUN mkdir -p ~/.cargo && \
    echo '[source.crates-io]\nreplace-with = "ustc"' > ~/.cargo/config && \
    echo '[source.ustc]\nregistry = "https://mirrors.ustc.edu.cn/crates.io-index/"' >> ~/.cargo/config

# 缓存依赖安装
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() { println!(\"Dummy\"); }" > src/main.rs
RUN cargo build --release
RUN rm -rf src

# 构建实际应用
COPY . .
RUN cargo install --path .

# 第二阶段：创建轻量级运行环境
FROM gcr.io/distroless/cc-debian11

# 从构建阶段复制二进制文件
COPY --from=builder /usr/local/cargo/bin/room-reg-impl /usr/local/bin/

# 运行应用
CMD ["room-reg-impl"]