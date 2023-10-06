local GwaIpAnonymousHandler = {
  VERSION  = "1.0.0",
  PRIORITY = 10000,
}

function anonymizeIps(conf, ips)
  if ips == nil or type(ips) ~= "string" then
    return nil
  else
    -- ipv6
    local ipv6Mask = conf.ipv6_mask or '0'
    ips = ips:gsub('([%da-fA-F]*:[%da-fA-F:]*:)[%da-fA-F]+', '%1'..ipv6Mask)
    
    -- ipv4
    local ipv4Mask = conf.ipv4_mask or '0'
    ips = ips:gsub('(%d+%.%d+%.%d+%.)%d+', '%1'..ipv4Mask)
    return ips
  end
end

function anonymizeHeaderIps(conf, name)
  local ips = ngx.req.get_headers()[name];
  ips = anonymizeIps(conf, ips)
  ngx.req.set_header(name, ips)
  return ips
end

function GwaIpAnonymousHandler:access(conf)
  anonymizeHeaderIps(conf, 'Forwarded')
  anonymizeHeaderIps(conf, 'x-forwarded-for')
  ngx.var.upstream_x_forwarded_for = anonymizeIps(conf, ngx.var.upstream_x_forwarded_for)
end

return GwaIpAnonymousHandler
