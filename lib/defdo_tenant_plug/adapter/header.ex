defmodule Defdo.TenantPlug.Adapter.Header do
  @moduledoc """
  Resolves a tenant from a request header.

  By default it reads `x-tenant-id` and resolves the tenant through
  `Defdo.Tenant.get_profile_by/1 |> one(skip_tenant_id: true)`.
  """

  @behaviour Defdo.TenantPlug.Adapter

  import Plug.Conn, only: [get_req_header: 2]

  @impl true
  def init(opts), do: opts

  @impl true
  def tenant_from_conn(conn, opts) do
    header = Keyword.get(opts, :header, "x-tenant-id")
    tenant_module = Keyword.get(opts, :tenant_module, Defdo.Tenant)
    lookup_key = Keyword.get(opts, :lookup_key, "tenant_id")

    case get_req_header(conn, header) do
      [value | _] when is_binary(value) and value != "" ->
        %{lookup_key => value}
        |> tenant_module.get_profile_by()
        |> tenant_module.one(skip_tenant_id: true)
        |> case do
          nil -> :error
          tenant -> {:ok, tenant}
        end

      _ ->
        :error
    end
  end
end
