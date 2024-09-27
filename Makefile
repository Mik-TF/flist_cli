# Makefile for Flist CLI

# Define the target binary location
BINARY_LOCATION = /usr/local/bin/flist

.PHONY: build clean

build:
	@echo "Building Flist CLI..."
	@if [ -f "flist.sh" ]; then \
		sudo cp flist.sh $(BINARY_LOCATION); \
		sudo chmod +xs $(BINARY_LOCATION); \
		echo "Flist CLI has been installed to $(BINARY_LOCATION)"; \
		echo "You can now use it by running 'flist help'"; \
	else \
		echo "Error: flist.sh not found in the current directory"; \
		exit 1; \
	fi

clean:
	@echo "Removing Flist CLI..."
	@if [ -f "$(BINARY_LOCATION)" ]; then \
		sudo rm $(BINARY_LOCATION); \
		echo "Flist CLI has been removed from $(BINARY_LOCATION)"; \
	else \
		echo "Flist CLI is not installed at $(BINARY_LOCATION)"; \
	fi