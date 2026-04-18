# DefdoTenantPlug

`DefdoTenantPlug` standardizes tenant resolution and injection across Defdo host apps.

It provides:

- a plug-friendly adapter behaviour
- a host-based adapter for `Defdo.Tenant`
- a header adapter
- a session adapter
- a single plug to resolve and inject tenant state
- helper accessors for tenant and tenant id
- optional bridges for Ash and Absinthe
- a LiveView `on_mount` helper

## Installation

```elixir
def deps do
  [
    {:defdo_tenant_plug, "~> 0.1", organization: "defdo"}
  ]
end
```

## Router usage

```elixir
pipeline :json_api do
  plug DefdoTenantPlug.Plug,
    adapter: DefdoTenantPlug.Adapter.Host,
    ash: true,
    absinthe: true,
    assign: :tenant,
    put_session: false
end
```

If you want to avoid the Ash deprecation around `assigns.tenant`, skip `assign: :tenant`
and read the full tenant through `DefdoTenantPlug.tenant(conn)` instead.

## Header adapter

```elixir
plug DefdoTenantPlug.Plug,
  adapter: DefdoTenantPlug.Adapter.Header,
  adapter_opts: [header: "x-tenant-id"],
  ash: true
```

## Session adapter

```elixir
plug DefdoTenantPlug.Plug,
  adapter: DefdoTenantPlug.Adapter.Session,
  put_session: true
```

## LiveView usage

```elixir
live_session :admin,
  on_mount: [{DefdoTenantPlug.LiveView, {:default, assign_key: :tenant}}] do
  # routes
end
```

## Adapter contract

Adapters implement:

```elixir
@callback init(keyword()) :: keyword()
@callback tenant_from_conn(Plug.Conn.t(), keyword()) :: {:ok, tenant} | :error
```

## Initial migration plan

1. Replace host-local tenant plugs with `DefdoTenantPlug.Plug`
2. Keep existing router order
3. Move Ash integration into package config instead of host-local code
4. Standardize LiveView tenant restoration through `DefdoTenantPlug.LiveView`

## Publish check

```bash
mix test
mix precommit
mix hex.build
```
