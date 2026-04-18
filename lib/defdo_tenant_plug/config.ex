defmodule Defdo.TenantPlug.Config do
  @moduledoc false

  def tenant_module(opts), do: Keyword.get(opts, :tenant_module, Defdo.Tenant)
  def tenant_id_field(opts), do: Keyword.get(opts, :tenant_id_field, :tenant_id)
end
