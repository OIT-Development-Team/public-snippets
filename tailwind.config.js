import defaultTheme from 'tailwindcss/defaultTheme';

/** @type {import('tailwindcss').Config} */
export default {
    content: [
        './vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php',
        './storage/framework/views/*.php',
        './resources/**/*.blade.php',
        './resources/**/*.js',
        './resources/**/*.vue',
    ],
    theme: {
        extend: {
            fontFamily: {
                sans: ['Figtree', ...defaultTheme.fontFamily.sans],
            },
            colors: {
                'ua-gray': {
                    DEFAULT: '#eeeeee'
                },
                'crimson': {
                    DEFAULT: '#9e1c32',
                    '50': '#ff6262',
                    '100': '#FF3D3D',
                    '200': '#FF1414',
                    '300': '#EB0000',
                    '400': '#C20000',
                    '500': '##9e1c32',
                    '600': '#610000',
                    '700': '#290000',
                    '800': '#000000',
                    '900': '#000000'
                },
            }
        },
    },
    plugins: [],
};


