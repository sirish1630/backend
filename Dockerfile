FROM python:3.12-bookworm

# Set the working directory
WORKDIR /app

# Install curl and CA certs for downloading uv
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates \
  && curl -Ls https://astral.sh/uv/install.sh | sh \
  && apt-get purge -y --auto-remove curl \
  && rm -rf /var/lib/apt/lists/*

# Ensure uv is on PATH
ENV PATH="/root/.local/bin:$PATH"

# Copy only dependency files first to leverage Docker layer caching
COPY pyproject.toml uv.lock ./

# Sync dependencies using uv
RUN uv venv && uv pip install --upgrade pip && uv sync --frozen

# Add .venv to path
ENV PATH="/app/.venv/bin:$PATH"

# Copy the entire app source
COPY . .

# Expose FastAPI port
EXPOSE 8000

# Set the entrypoint
CMD ["./start.sh"]
