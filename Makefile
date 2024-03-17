all:  generate-openapi



# Base Paths
PROTO_DIR=proto
PROTO_FILES=$(shell find $(PROTO_DIR) -name '*.proto')
OPENAPI_OUT_DIR=openapi


# Vendoring Paths
VENDOR_DIR=vendor
GOOGLE_APIS_DIR=$(VENDOR_DIR)/googleapis
GRPC_GATEWAY_DIR=$(VENDOR_DIR)/grpc-gateway



CREATE_OPENAPI_OUT_DIR:
	@echo Creating directory $(OPENAPI_OUT_DIR)
	@mkdir -p $(OPENAPI_OUT_DIR)


# Installing Tools For Code Generation; Using Golang
setup-golang-tools:
	@echo "Setup golang tools"
	@go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest


# Vendoring Dependencies
vendor:
	@echo "Vendoring dependencies"
	@echo "After vendoring completes, if you use jetbrains ide, enhance IDE dependency recognition with this quick setup: Go to Settings > Languages & Frameworks > Protocol Buffers > Import Paths, and add the path to your new dependency folder."
	@if [ ! -d "$(VENDOR_DIR)" ]; then \
  		echo "Creating vendor directory"; \
		mkdir -p $(VENDOR_DIR); \
	fi
	@if [ ! -d "$(GOOGLE_APIS_DIR)" ] || [ -z "$$(ls -A $(GOOGLE_APIS_DIR) 2>/dev/null)"  ]; then \
  		echo "Vendoring googleapis"; \
		git submodule add --force https://github.com/googleapis/googleapis.git $(GOOGLE_APIS_DIR); \
		echo "Done vendoring googleapis"; \
	fi
	@if [ ! -d "$(GRPC_GATEWAY_DIR)" ] || [ -z "$$(ls -A $(GRPC_GATEWAY_DIR) 2>/dev/null)" ]; then \
  		echo "Vendoring grpc-gateway"; \
		git submodule add --force https://github.com/grpc-ecosystem/grpc-gateway.git $(GRPC_GATEWAY_DIR); \
	fi
	@echo "Dependencies vendored"

# Generating Open Api Spec From Protobuf
generate-openapi: CREATE_OPENAPI_OUT_DIR
	@echo "Generating Open Api Spec."
	@protoc -I$(PROTO_DIR) \
	-I$(GOOGLE_APIS_DIR) \
	-I$(GRPC_GATEWAY_DIR) \
	--openapiv2_out=$(OPENAPI_OUT_DIR) \
	--openapiv2_opt=use_go_templates=true,preserve_rpc_order=true \
	$(PROTO_FILES)




