defmodule Upload.ResizerMock do
  def resize(_url, _width, _height) do
    status = 200

    headers = [
      {"date", "Tue, 05 Mar 2019 10:03:07 GMT"},
      {"etag", "\"92263e087855af5c050ad1ff7a821310056cdbbf\""},
      {"server", "TornadoServer/4.5.3"},
      {"content-length", "7"},
      {"content-type", "text/html; charset=UTF-8"}
    ]

    body = "body"

    {:ok, status, headers, body}
  end
end
