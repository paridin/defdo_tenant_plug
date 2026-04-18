if Code.ensure_loaded?(Phoenix.Component) do
  defmodule Defdo.TenantPlug.LiveView do
    @moduledoc """
    LiveView helpers for restoring a tenant from session.
    """

    import Phoenix.Component, only: [assign: 3]

    @doc """
    Mounts tenant data from session.

    Supported mount arguments:

    - `:default`
    - `{:default, opts}`

    Options:

    - `:tenant_module` - module used to fetch the tenant, defaults to `Defdo.Tenant`
    - `:session_key` - session key for tenant id, defaults to `"tenant_id"`
    - `:assign_key` - assign name for the tenant struct, defaults to `:tenant`
    - `:tenant_id_assign_key` - assign name for the tenant id, defaults to `:tenant_id`
    """
    def on_mount(config, _params, session, socket) do
      opts = normalize_opts(config)
      session_key = Keyword.get(opts, :session_key, "tenant_id")

      case Map.get(session, session_key) do
        tenant_id when is_binary(tenant_id) and tenant_id != "" ->
          tenant_module = Defdo.TenantPlug.Config.tenant_module(opts)
          tenant = tenant_module.get_profile!(tenant_id)

          tenant_module.inject_tenant(tenant_id)

          socket =
            socket
            |> assign(Keyword.get(opts, :assign_key, :tenant), tenant)
            |> assign(Keyword.get(opts, :tenant_id_assign_key, :tenant_id), tenant_id)

          {:cont, socket}

        _ ->
          {:cont, socket}
      end
    end

    defp normalize_opts(:default), do: []
    defp normalize_opts({:default, opts}) when is_list(opts), do: opts
    defp normalize_opts(_other), do: []
  end
else
  defmodule Defdo.TenantPlug.LiveView do
    @moduledoc false

    def on_mount(_config, _params, _session, _socket) do
      raise ArgumentError,
            "Defdo.TenantPlug.LiveView requires :phoenix_live_view to be available"
    end
  end
end
