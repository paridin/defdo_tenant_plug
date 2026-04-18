defmodule Defdo.TenantPlug do
  @moduledoc """
  Standard tenant resolution and injection flow for Defdo hosts.

  The package resolves a tenant from the current request through an adapter,
  injects the tenant into `Defdo.Tenant`, stores tenant metadata in
  `conn.private`, and can optionally bridge the resolved tenant into Ash,
  Absinthe, and LiveView.
  """

  alias Plug.Conn

  @private_key :defdo_tenant_plug

  @spec private_key() :: atom()
  def private_key, do: @private_key

  @spec tenant(Conn.t()) :: term() | nil
  def tenant(%Conn{private: %{@private_key => %{tenant: tenant}}}), do: tenant
  def tenant(_conn), do: nil

  @spec tenant_id(Conn.t()) :: term() | nil
  def tenant_id(%Conn{private: %{@private_key => %{tenant_id: tenant_id}}}), do: tenant_id
  def tenant_id(_conn), do: nil

  @spec put(Conn.t(), term(), term()) :: Conn.t()
  def put(%Conn{} = conn, tenant, tenant_id) do
    Conn.put_private(conn, @private_key, %{tenant: tenant, tenant_id: tenant_id})
  end

  @spec fetch(Conn.t()) :: %{tenant: term(), tenant_id: term()} | nil
  def fetch(%Conn{private: %{@private_key => state}}), do: state
  def fetch(_conn), do: nil
end
