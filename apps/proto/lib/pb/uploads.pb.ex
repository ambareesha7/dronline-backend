defmodule Proto.Uploads.UploadResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          upload_url: String.t(),
          download_url: String.t()
        }

  defstruct [:upload_url, :download_url]

  field :upload_url, 1, type: :string
  field :download_url, 2, type: :string
end

defmodule Proto.Uploads.GetFileUploadUrlResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          upload_url: String.t(),
          resource_path: String.t()
        }

  defstruct [:upload_url, :resource_path]

  field :upload_url, 1, type: :string
  field :resource_path, 2, type: :string
end

defmodule Proto.Uploads.PostDocumentToVisitRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          file_name: String.t(),
          content_type: String.t(),
          record_id: non_neg_integer
        }

  defstruct [:file_name, :content_type, :record_id]

  field :file_name, 1, type: :string
  field :content_type, 2, type: :string
  field :record_id, 3, type: :uint64
end
