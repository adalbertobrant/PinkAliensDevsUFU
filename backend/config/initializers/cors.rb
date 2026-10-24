# CORS — permite que o frontend (SPA) acesse a API.
# Em desenvolvimento, aceita localhost e a origem `null` (abertura via file://).
# Em produção, defina CORS_ORIGINS no .env com os domínios permitidos.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*ENV.fetch('CORS_ORIGINS', 'http://localhost:3000,http://localhost:5173,http://localhost:8080,null')
                .split(',')
                .map(&:strip))

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
