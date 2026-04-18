defmodule DefdoTenantPlug.PlugTest do
  use ExUnit.Case, async: true

  import Plug.Conn
  import Plug.Test

  defmodule TenantStub do
    def inject_tenant(_tenant_id), do: :ok
  end

  defmodule AdapterStub do
    @behaviour DefdoTenantPlug.Adapter

    @impl true
    def init(opts), do: opts

    @impl true
    def tenant_from_conn(_conn, opts) do
      case Keyword.fetch(opts, :tenant) do
        {:ok, tenant} -> {:ok, tenant}
        :error -> :error
      end
    end
  end

  test "stores tenant in private and assigns tenant_id by default" do
    tenant = %{tenant_id: "tenant-1", name: "Acme"}

    conn =
      :get
      |> conn("/")
      |> init_test_session(%{})
      |> DefdoTenantPlug.Plug.call(
        DefdoTenantPlug.Plug.init(
          adapter: AdapterStub,
          adapter_opts: [tenant: tenant],
          tenant_module: TenantStub
        )
      )

    assert DefdoTenantPlug.tenant(conn) == tenant
    assert DefdoTenantPlug.tenant_id(conn) == "tenant-1"
    assert conn.assigns.tenant_id == "tenant-1"
    assert is_nil(conn.assigns[:tenant])
  end

  test "can assign tenant under a custom key" do
    tenant = %{tenant_id: "tenant-2", name: "Beta"}

    conn =
      :get
      |> conn("/")
      |> init_test_session(%{})
      |> DefdoTenantPlug.Plug.call(
        DefdoTenantPlug.Plug.init(
          adapter: AdapterStub,
          adapter_opts: [tenant: tenant],
          tenant_module: TenantStub,
          assign: :tenant
        )
      )

    assert conn.assigns.tenant == tenant
  end

  test "stores tenant_id in session when enabled" do
    tenant = %{tenant_id: "tenant-3"}

    conn =
      :get
      |> conn("/")
      |> init_test_session(%{})
      |> DefdoTenantPlug.Plug.call(
        DefdoTenantPlug.Plug.init(
          adapter: AdapterStub,
          adapter_opts: [tenant: tenant],
          tenant_module: TenantStub,
          put_session: true
        )
      )

    assert get_session(conn, "tenant_id") == "tenant-3"
  end

  test "halts on missing tenant when configured" do
    conn =
      :get
      |> conn("/")
      |> DefdoTenantPlug.Plug.call(
        DefdoTenantPlug.Plug.init(
          adapter: AdapterStub,
          adapter_opts: [],
          tenant_module: TenantStub,
          on_missing: :halt
        )
      )

    assert conn.halted
  end

  test "raises on missing tenant by default" do
    assert_raise RuntimeError, ~r/tenant is configured for your domain/, fn ->
      :get
      |> conn("/")
      |> DefdoTenantPlug.Plug.call(
        DefdoTenantPlug.Plug.init(
          adapter: AdapterStub,
          adapter_opts: [],
          tenant_module: TenantStub
        )
      )
    end
  end
end
