# There's probably a function out there that does this, but anyway

function max_non_nan(array)
    filtered_array = filter(!isnan, array)
    isempty(filtered_array) ? NaN : maximum(filtered_array)
end