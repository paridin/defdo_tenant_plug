defmodule Defdo.TenantPlug.Plug do
  @moduledoc """
  Resolves and injects tenant state into the request lifecycle.

  Options:

    * `:adapter` - adapter module, defaults to `Defdo.TenantPlug.Adapter.Host`
    * `:adapter_opts` - options forwarded to the adapter
    * `:tenant_module` - tenant module used for `inject_tenant/1`, defaults to `Defdo.Tenant`
    * `:tenant_id_field` - tenant id field in the tenant struct, defaults to `:tenant_id`
    * `:put_session` - store `"tenant_id"` in session, defaults to `false`
    * `:ash` - bridge to `Ash.PlugHelpers.set_tenant/2`, defaults to `false`
    * `:absinthe` - bridge to `Absinthe.Plug.assign_context/3`, defaults to `false`
    * `:on_missing` - `:raise` or `:halt`, defaults to `:raise`
    * `:assign` - assign the tenant struct under a specific key, defaults to `nil`
    * `:assign_tenant_id` - assign tenant id under a specific key, defaults to `:tenant_id`
  """

  @behaviour Plug

  import Plug.Conn, only: [assign: 3, halt: 1, put_session: 3]

  alias Defdo.TenantPlug.Config

  @impl true
  def init(opts) do
    adapter = Keyword.get(opts, :adapter, Defdo.TenantPlug.Adapter.Host)
    adapter_opts = adapter.init(Keyword.get(opts, :adapter_opts, []))

    opts
    |> Keyword.put(:adapter, adapter)
    |> Keyword.put(:adapter_opts, adapter_opts)
  end

  @impl true
  def call(conn, opts) do
    case opts[:adapter].tenant_from_conn(conn, opts[:adapter_opts]) do
      {:ok, tenant} ->
        tenant_id = Map.fetch!(tenant, Config.tenant_id_field(opts))
        tenant_module = Config.tenant_module(opts)

        tenant_module.inject_tenant(tenant_id)

        conn
        |> Defdo.TenantPlug.put(tenant, tenant_id)
        |> maybe_assign_tenant(tenant, opts)
        |> maybe_assign_tenant_id(tenant_id, opts)
        |> maybe_put_session(tenant_id, opts)
        |> maybe_set_ash_tenant(tenant, opts)
        |> maybe_put_absinthe_context(tenant, tenant_id, opts)

      :error ->
        handle_missing_tenant(conn, opts)
    end
  end

  defp maybe_assign_tenant(conn, tenant, opts) do
    case Keyword.get(opts, :assign) do
      nil -> conn
      key -> assign(conn, key, tenant)
    end
  end

  defp maybe_assign_tenant_id(conn, tenant_id, opts) do
    case Keyword.get(opts, :assign_tenant_id, :tenant_id) do
      nil -> conn
      key -> assign(conn, key, tenant_id)
    end
  end

  defp maybe_put_session(conn, tenant_id, opts) do
    if Keyword.get(opts, :put_session, false) do
      put_session(conn, "tenant_id", tenant_id)
    else
      conn
    end
  end

  defp maybe_set_ash_tenant(conn, tenant, opts) do
    if Keyword.get(opts, :ash, false) and Code.ensure_loaded?(Ash.PlugHelpers) do
      Ash.PlugHelpers.set_tenant(conn, tenant)
    else
      conn
    end
  end

  defp maybe_put_absinthe_context(conn, tenant, tenant_id, opts) do
    if Keyword.get(opts, :absinthe, false) and Code.ensure_loaded?(Absinthe.Plug) do
      conn
      |> Absinthe.Plug.assign_context(:tenant, tenant)
      |> Absinthe.Plug.assign_context(:tenant_id, tenant_id)
    else
      conn
    end
  end

  defp handle_missing_tenant(conn, opts) do
    case Keyword.get(opts, :on_missing, :raise) do
      :halt -> halt(conn)
      :raise -> raise missing_tenant_message(conn)
    end
  end

  defp missing_tenant_message(conn) do
    """
    Your app is not configured correctly, please ensure that a tenant is configured for your domain: #{conn.host}.
    """
  end
end
