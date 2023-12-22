defmodule MyAppWeb.Auth.Guardian do
  use Guardian, otp_app: :my_app
  alias MyAppWeb.Auth.ErrorResponse
  alias MyApp.Users

  def subject_for_token(%{id: id}, _claims) do
    subject = to_string(id)
    {:ok, subject}
  end

  def subject_for_token(_,_) do
    {:error, :no_id_provided}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Users.get_user!(id) do
      nil -> raise ErrorResponse.NotFound
      resource -> {:ok, resource}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :no_id_provided}
  end

  def authenticate(credential, credential_type, password) do
    case credential_type do
      "email" ->
        case Users.get_user_by_email!(credential) do
          nil -> {:error, :unauthorized}
          user ->
            case validate_password(password, user.password_hash) do
              true -> create_token(user)
              false -> {:error, :unauthorized}
            end
        end
      "mobile" ->
        case Users.get_user_by_mobile!(credential) do
          nil -> {:error, :unauthorized}
          user ->
            case validate_password(password, user.password_hash) do
              true -> create_token(user)
              false -> {:error, :unauthorized}
            end
        end
    end
  end

  def authenticate(token) do
    with {:ok, claims} <- decode_and_verify(token),
         {:ok, user} <- resource_from_claims(claims),
         {:ok, _old, {new_token,  _claims}} <- refresh(token) do

      {:ok, user, new_token}
    else
      {:error, _message} -> raise ErrorResponse.NotFound
    end
  end

  def validate_password(password, hash_password) do
    Bcrypt.verify_pass(password, hash_password)
  end

  defp create_token(user) do
    {:ok, token, _claims} = encode_and_sign(user)
    {:ok, user, token}
  end


  def after_encode_and_sign(resource, claims, token, _options) do
    with {:ok, _} <- Guardian.DB.after_encode_and_sign(resource, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  def on_verify(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_verify(claims, token) do
      {:ok, claims}
    end
  end

  def on_refresh({old_token, old_claims}, {new_token, new_claims}, _options) do
    with {:ok, _, _} <- Guardian.DB.on_refresh({old_token, old_claims}, {new_token, new_claims}) do
      {:ok, {old_token, old_claims}, {new_token, new_claims}}
    end
  end

  def on_revoke(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_revoke(claims, token) do
      {:ok, claims}
    end
  end

end
