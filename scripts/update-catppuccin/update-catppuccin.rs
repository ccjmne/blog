use std::{env::args, fs::read_to_string, str::FromStr};
use sublime_color_scheme::ColorScheme;
use syntect::{
    highlighting::Theme,
    html::{ClassStyle, css_for_theme_with_class_style},
};

fn main() {
    let scheme = read_to_string(args().nth(1).unwrap()).unwrap();
    let theme = Theme::try_from(ColorScheme::from_str(&scheme).unwrap()).unwrap();
    println!("{}", css_for_theme_with_class_style(&theme, ClassStyle::SpacedPrefixed { prefix: "z-" }).unwrap());
}
