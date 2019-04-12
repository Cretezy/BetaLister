const mobileSize = 576;
const tabletSize = 768;

export const mobileOnly = `(max-width: ${mobileSize}px)`;
export const tabletAndUp = `(min-width: ${mobileSize}px)`;
export const tabletOnly = `${tabletAndUp} and (max-width: ${tabletSize}px)`;
