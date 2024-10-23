defmodule Proto.MedicalCategories.MedicalCategory.VisitType do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3
  @type t :: integer | :ONLINE | :IN_OFFICE | :BOTH

  field :ONLINE, 0

  field :IN_OFFICE, 1

  field :BOTH, 2
end

defmodule Proto.MedicalCategories.GetMedicalCategoriesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          categories: [Proto.MedicalCategories.MedicalCategory.t()]
        }

  defstruct [:categories]

  field :categories, 1, repeated: true, type: Proto.MedicalCategories.MedicalCategory
end

defmodule Proto.MedicalCategories.GetMedicalCategoryResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          category: Proto.MedicalCategories.MedicalCategory.t() | nil,
          subcategories: [Proto.MedicalCategories.MedicalCategory.t()]
        }

  defstruct [:category, :subcategories]

  field :category, 1, type: Proto.MedicalCategories.MedicalCategory
  field :subcategories, 2, repeated: true, type: Proto.MedicalCategories.MedicalCategory
end

defmodule Proto.MedicalCategories.GetMedicalCategoryFeaturedDoctorsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          deprecated: [Proto.Doctors.FeaturedDoctor.t()],
          featured_doctors: [Proto.Generics.Specialist.t()]
        }

  defstruct [:deprecated, :featured_doctors]

  field :deprecated, 1, repeated: true, type: Proto.Doctors.FeaturedDoctor
  field :featured_doctors, 2, repeated: true, type: Proto.Generics.Specialist
end

defmodule Proto.MedicalCategories.GetAllMedicalCategoriesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          categories: [Proto.MedicalCategories.MedicalCategoryBase.t()]
        }

  defstruct [:categories]

  field :categories, 1, repeated: true, type: Proto.MedicalCategories.MedicalCategoryBase
end

defmodule Proto.MedicalCategories.UpdateMedicalCategoryResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          categories: Proto.MedicalCategories.MedicalCategoryBase.t() | nil
        }

  defstruct [:categories]

  field :categories, 1, type: Proto.MedicalCategories.MedicalCategoryBase
end

defmodule Proto.MedicalCategories.UpdateMedicalCategoryRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          disabled: boolean,
          position: non_neg_integer
        }

  defstruct [:id, :disabled, :position]

  field :id, 1, type: :uint64
  field :disabled, 2, type: :bool
  field :position, 3, type: :uint64
end

defmodule Proto.MedicalCategories.MedicalCategory do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          name: String.t(),
          image_url: String.t(),
          icon_url: String.t(),
          what_we_treat_url: String.t(),
          visit_type: Proto.MedicalCategories.MedicalCategory.VisitType.t()
        }

  defstruct [:id, :name, :image_url, :icon_url, :what_we_treat_url, :visit_type]

  field :id, 1, type: :uint64
  field :name, 2, type: :string
  field :image_url, 3, type: :string
  field :icon_url, 4, type: :string
  field :what_we_treat_url, 5, type: :string
  field :visit_type, 6, type: Proto.MedicalCategories.MedicalCategory.VisitType, enum: true
end

defmodule Proto.MedicalCategories.MedicalCategoryBase do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: non_neg_integer,
          name: String.t(),
          parent_category_id: non_neg_integer
        }

  defstruct [:id, :name, :parent_category_id]

  field :id, 1, type: :uint64
  field :name, 2, type: :string
  field :parent_category_id, 3, type: :uint64
end
