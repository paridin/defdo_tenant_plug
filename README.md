# Defdo.TenantPlug

`Defdo.TenantPlug` standardizes tenant resolution and injection across Defdo host apps.

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
  plug Defdo.TenantPlug.Plug,
    adapter: Defdo.TenantPlug.Adapter.Host,
    ash: true,
    absinthe: true,
    assign: :tenant,
    put_session: false
end
```

If you want to avoid the Ash deprecation around `assigns.tenant`, skip `assign: :tenant`
and read the full tenant through `Defdo.TenantPlug.tenant(conn)` instead.

## Header adapter

```elixir
plug Defdo.TenantPlug.Plug,
  adapter: Defdo.TenantPlug.Adapter.Header,
  adapter_opts: [header: "x-tenant-id"],
  ash: true
```

## Session adapter

```elixir
plug Defdo.TenantPlug.Plug,
  adapter: Defdo.TenantPlug.Adapter.Session,
  put_session: true
```

## LiveView usage

```elixir
live_session :admin,
  on_mount: [{Defdo.TenantPlug.LiveView, {:default, assign_key: :tenant}}] do
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

1. Replace host-local tenant plugs with `Defdo.TenantPlug.Plug`
2. Keep existing router order
3. Move Ash integration into package config instead of host-local code
4. Standardize LiveView tenant restoration through `Defdo.TenantPlug.LiveView`

## Publish check

```bash
mix test
mix precommit
mix hex.build
```
