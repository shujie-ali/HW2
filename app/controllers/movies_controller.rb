class MoviesController < ApplicationController
  
  @@initialRatings = {'G'=>"yes", 'R'=>"yes", 'PG'=>"yes", 'PG-13'=>"yes",'NC-17'=>"yes"}
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # checking if sort commands changes otherwise keep it as previous
    category_sort = params[:sort_by]
    if "title"== params[:sort_by] || "release_date" == params[:sort_by]
      session[:sort_by] = category_sort
    else
      category_sort = session[:sort_by]
    end
    #lisiting all movies
    @movies = Movie.all.order(params[:sort_by])
    #Checkbox ratting checking
    @selectedRatings = params[:ratings] || session[:rating]
    
    if @selectedRatings.nil?
      @selectedRatings = @@initialRatings
      @movies = @movies.where(:rating => @selectedRatings.keys).all
    else
      if @@initialRatings.include_hash?(@selectedRatings)
        session[:rating] = @selectedRatings
        @movies = @movies.where(:rating => @selectedRatings.keys).all
      else
        @selectedRatings = session[:rating]
        @movies = @movies.where(:rating => @selectedRatings.keys).all
      end
    end
  end


  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end
  
  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end
  
  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
  def delete
    titleIdentifier = params[:movie][:title]
    rattingIdentifier = params[:movie][:rating]
    movieByTitle = Movie.find_by_title(titleIdentifier)
    movieByRatting = Movie.find_by_rating(rattingIdentifier)
    if (not (movieByTitle.nil? or titleIdentifier == ""))
      movieByTitle.destroy
    end
    while(not(rattingIdentifier == "---" or movieByRatting.nil?))
      movieByRatting.destroy
      movieByRatting = Movie.find_by_rating(rattingIdentifier)
    end
    redirect_to movies_path
  end
  
  def movieUpdate
    movieIdentifier = params[:movie][:title]
    checkMovie = Movie.find_by_title(movieIdentifier)
    if (checkMovie.nil?)
      flash[:notice] = "cannot find: #{movieIdentifier}"
    else
      myDate =  Date.new params[:movie]["release_date(1i)"].to_i, params[:movie]["release_date(2i)"].to_i, params[:movie]["release_date(3i)"].to_i
      newTitle = params[:movie][:newtitle]
      newRating = params[:movie][:rating]
      if (myDate.nil? or newTitle == "" or newRating =='---')
        flash[:notice] = "Incomplete feilds" 
      else
        checkMovie.update_attribute(:title,newTitle)
        checkMovie.update_attribute(:rating,newRating)
        checkMovie.update_attribute(:release_date,myDate)
        flash[:notice] = "Movie edited: #{newTitle}"
      end
    end
    redirect_to movies_path
  end

  
end