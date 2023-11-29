/// Polynomial root trick to minimize the number of circuits.
/// A range comparisons cannot work on Field arithmetic i.e. we cannot use gt, lt operators
/// on Field types. Typically, we would have to convert Field into Integer and then do comparisons.
/// However, this adds a significant number of circuits. Here we use the polynomial root trick to 
/// efficiently perform range comparisons.
/// Note! this only make sense for a given ranges. If it is too wide then simply converting into
/// Integer might be more efficient.
mod full_inclusive;
mod left_inclusive;
mod right_inclusive;
