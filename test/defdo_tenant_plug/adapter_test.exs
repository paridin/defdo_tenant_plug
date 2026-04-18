defmodule DefdoTenantPlug.AdapterTest do
  use ExUnit.Case, async: true

  import Plug.Conn
  import Plug.Test

  defmodule TenantStub do
    def get_profile_by(filters), do: {:filters, filters}

    def one({:filters, filters}, skip_tenant_id: true),
      do: Map.get(filters, "tenant_id") && %{tenant_id: filters["tenant_id"]}

    def get_profile!(tenant_id), do: %{tenant_id: tenant_id}
  end

  test "header adapter resolves tenant from request header" do
    conn =
      :get
      |> conn("/")
      |> put_req_header("x-tenant-id", "tenant-header")

    assert {:ok, %{tenant_id: "tenant-header"}} =
             DefdoTenantPlug.Adapter.Header.tenant_from_conn(
               conn,
               header: "x-tenant-id",
               tenant_module: TenantStub
             )
  end

  test "header adapter returns error when header is missing" do
    conn = conn(:get, "/")

    assert :error =
             DefdoTenantPlug.Adapter.Header.tenant_from_conn(
               conn,
               header: "x-tenant-id",
               tenant_module: TenantStub
             )
  end

  test "session adapter resolves tenant from session" do
    conn =
      :get
      |> conn("/")
      |> init_test_session(%{"tenant_id" => "tenant-session"})

    assert {:ok, %{tenant_id: "tenant-session"}} =
             DefdoTenantPlug.Adapter.Session.tenant_from_conn(
               conn,
               tenant_module: TenantStub
             )
  end

  test "session adapter returns error when session key is missing" do
    conn =
      :get
      |> conn("/")
      |> init_test_session(%{})

    assert :error =
             DefdoTenantPlug.Adapter.Session.tenant_from_conn(
               conn,
               tenant_module: TenantStub
             )
  end
end
