defmodule Kaufmann.TestSupport.MockSchemaRegistry do
  @moduledoc """
  A simple immitation schema registry that verifies Test Events against the schemas we have saved to file
  """
  @schema_path Kaufmann.Config.schema_path()

  def fetch_event_schema(schema_name) do
    schema_name
    |> load_schema
    |> inject_metadata
    |> AvroEx.parse_schema!()
  end

  @spec defined_event?(String.t()) :: boolean
  def defined_event?(schema_name) do
    @schema_path
    |> Path.join([schema_name |> to_string, ".avsc"])
    |> File.exists?()
  end

  @spec encodable?(String.t(), any) :: boolean
  def encodable?(schema_name, payload) do
    schema_name
    |> fetch_event_schema
    |> AvroEx.encodable?(payload)
  end

  defp inject_metadata(schema) do
    # Decode + encode here is dumb and time consuming
    schema
    |> Poison.decode!()
    |> List.wrap()
    |> List.insert_at(0, load_metadata())
    |> Poison.encode!()
  end

  defp load_schema(schema_name) do
    {:ok, schema} =
      @schema_path
      |> Path.join([schema_name |> to_string, ".avsc"])
      |> File.read()

    schema
  end

  defp load_metadata do
    load_schema("event_metadata")
    |> Poison.decode!()
  end
end