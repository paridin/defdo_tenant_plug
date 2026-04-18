defmodule DefdoTenantPlug.Adapter do
  @moduledoc """
  Behaviour for request tenant resolution.
  """

  alias Plug.Conn

  @type opts :: keyword()
  @type tenant_result :: {:ok, term()} | :error

  @callback init(opts()) :: opts()
  @callback tenant_from_conn(Conn.t(), opts()) :: tenant_result()
end
