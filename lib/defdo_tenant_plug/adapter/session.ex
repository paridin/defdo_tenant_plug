defmodule DefdoTenantPlug.Adapter.Session do
  @moduledoc """
  Resolves a tenant from session state.

  By default it reads `"tenant_id"` from session and fetches the tenant through
  `Defdo.Tenant.get_profile!/1`.
  """

  @behaviour DefdoTenantPlug.Adapter

  import Plug.Conn, only: [get_session: 2]

  @impl true
  def init(opts), do: opts

  @impl true
  def tenant_from_conn(conn, opts) do
    session_key = Keyword.get(opts, :session_key, "tenant_id")
    tenant_module = Keyword.get(opts, :tenant_module, Defdo.Tenant)

    case get_session(conn, session_key) do
      tenant_id when is_binary(tenant_id) and tenant_id != "" ->
        {:ok, tenant_module.get_profile!(tenant_id)}

      _ ->
        :error
    end
  end
end
