class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  def index
    if params[:query]
      data = MovieWrapper.search(params[:query])
    else
      data = Movie.all
    end

    render status: :ok, json: data
  end

  def show
    render(
    status: :ok,
    json: @movie.as_json(
    only: [:title, :overview, :release_date, :inventory],
    methods: [:available_inventory]
    )
    )
  end

  def create
    existing_movie = Movie.find_by(overview: movie_params[:overview])

    if existing_movie
      render json: {errors: {movie: ["#{params[:title]} is already in Video Store"]}}
    else
      movie = Movie.new(movie_params)
      movie.inventory = 1;
      if movie.save
        render json: movie.as_json, status: :ok
      else
        render status: :bad_request, json: {errors: movie.errors.messages}
      end
    end

  end

  private

  def movie_params
    params.require(:movie).permit(:title, :overview, :release_date, :inventory, :image_url, :external_id)
  end

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
