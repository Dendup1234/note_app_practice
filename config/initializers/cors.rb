# Setting up the cors
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Specify the exact frontend domain (e.g., React/Vue/Angular app)
    origins "https://yourdomain.com", "http://localhost:3000"

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true
  end
end
