defmodule Defdo.TenantPlug.Adapter.Host do
  @moduledoc """
  Resolves a tenant from the incoming host using `Defdo.Tenant`.
  """

  @behaviour Defdo.TenantPlug.Adapter

  @impl true
  def init(opts), do: opts

  @impl true
  def tenant_from_conn(conn, opts) do
    tenant_module = Keyword.get(opts, :tenant_module, Defdo.Tenant)
    lookup_key = Keyword.get(opts, :lookup_key, "via_domain")
    lookup = %{lookup_key => conn.host}

    case lookup |> tenant_module.get_profile_by() |> tenant_module.one(skip_tenant_id: true) do
      nil -> :error
      tenant -> {:ok, tenant}
    end
  end
end
