defmodule DoraM.Request do
  @req_options Application.compile_env!(:dora_m, :req_options)

  def get(url, headers, body \\ %{}) do
    Req.get(
      [url: url, headers: headers, body: body],
      @req_options
    )
  end

  def post(url, headers, body \\ %{}) do
    Req.post(
      [url: url, headers: headers, body: body],
      @req_options
    )
  end
end
