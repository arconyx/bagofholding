export interface Purse {
    platinum: number,
    gold: number,
    silver: number,
    copper: number
}

export function getPurseTotalGp(purse: Purse): number {
    return 10 * purse.platinum + purse.gold + 0.1 * purse.silver + 0.01 * purse.copper
}