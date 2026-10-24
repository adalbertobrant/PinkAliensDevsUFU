class Rack::Attack
  # Rate limit por IP
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  # Rate limit para upload
  throttle('uploads/ip', limit: 10, period: 1.hour) do |req|
    if req.path.include?('/api/upload') || req.path.include?('/api/lotes')
      req.ip
    end
  end

  # Bloquear IPs suspeitas se necessário
  self.throttled_responder = lambda do |env|
    [429, {'Content-Type' => 'application/json'}, [{ error: 'Muitas requisições. Tente novamente mais tarde.' }.to_json]]
  end
end
